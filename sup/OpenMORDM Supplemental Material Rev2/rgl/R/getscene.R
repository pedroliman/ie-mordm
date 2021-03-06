scene3d <- function() {
  
  defaultmaterial <- material3d()
  
  matdiff <- function(mat) {
    for (m in names(mat)) {
      if (identical(mat[[m]], defaultmaterial[[m]]))
        mat[[m]] <- NULL
    }
    mat
  }
  
  inbbox <- function(x, bbox) {
    if (is.null(x)) return(TRUE)
    x <- x[apply(x, 1, function(row) all(!is.na(row))),,drop=FALSE]
    if (!nrow(x)) return(TRUE)
    all(bbox[1] <= x[,1]) && all(x[,1] <= bbox[2]) &&
    all(bbox[3] <= x[,2]) && all(x[,2] <= bbox[4]) &&
    all(bbox[5] <= x[,3]) && all(x[,3] <= bbox[6])
  }
  
  getObject <- function(id, type) {
    result <- list(id=id, type=type)
    
    if (!(type %in% c("background", "bboxdeco")))
      result$material <- matdiff(rgl.getmaterial(id=id))
    
    attribs <- c("vertices", "normals", "colors", "texcoords", "dim",
          "texts", "cex", "adj", "radii", "ids",
          "usermatrix", "types" )
    for (a in attribs) 
      if (rgl.attrib.count(id, a))
        result[[a]] <- rgl.attrib(id, a)
    # FIXME:  we should query the ignoreExtent field instead
    if (!inbbox(result$vertices, scenebbox))
      result$ignoreExtent <- TRUE
    if (!is.null(result$ids)) {
      objlist <- vector("list", nrow(result$ids))
      for (i in seq_len(nrow(result$ids)))
        objlist[[i]] <- getObject(result$ids[i,1], result$types[i,1])
      result$objects <- objlist
    }
    class(result) <- c(paste0("rgl", type), "rglobject")
    result
  }

  scenebbox <- par3d("bbox")
      
  result <- list()

  result$par3d <- par3d()

  result$material <- defaultmaterial
    
  obj <- rgl.ids("background")
  bg <- getObject(obj$id, "background")
  col <- bg$colors
  bg$color <- rgb(col[,1], col[,2], col[,3])
  bg$colors <- NULL
  result$bg <- bg
  
  if (nrow(obj <- rgl.ids("bboxdeco")))
    result$bbox <- getObject(obj$id, "bboxdeco")
    
  objs <- rgl.ids()  
  objlist <- vector("list", nrow(objs))
  ids <- objs$id
  types <- as.character(objs$type)
  for (i in seq_len(nrow(objs))) 
    objlist[[i]] <- getObject(ids[i], types[i])
  result$objects <- objlist
    
  class(result) <- "rglscene"
  result
}

print.rglscene <- function(x, ...) {
  cat("RGL scene containing:\n")
  if (!is.null(x$par3d))
    cat("  par3d:\tscene information\n")
  if (!is.null(x$material))
    cat("  material:\tdefault material properties\n")
  if (!is.null(x$objects)) {
    cat("  objects:\tlist of", length(x$objects),"object(s):\n")
    cat("          \t", sapply(x$objects, function(obj) obj$type), "\n")
  }
  invisible(x)
}

print.rglobject <- function(x, ...) {
  cat("RGL object of type", x$type, "containing components\n")
  cat("  ")
  cat(names(x), sep=", ")
  cat("\n")
}

plot3d.rglscene <- function(x, add=FALSE, ...) {
  if (!add) {
    params <- getr3dDefaults()
    if (!is.null(x$material)) {
      if (is.null(params$material)) params$material <- list()
      params$material[names(x$material)] <- x$material
    }
    if (!is.null(x$bg)) {
      if (is.null(params$bg)) params$bg <- list()
      params$bg[names(x$bg)] <- x$bg
    }
    if (!is.null(x$par3d)) {
      ind <- !(names(x$par3d) %in% .Par3d.readonly)
      params[names(x$par3d)[ind]] <- x$par3d[ind]
    }
    open3d(params = params)
  }
    
  results <- c()
  for (i in seq_along(x$objects)) {
    obj <- x$objects[[i]]
    results <- c(results, plot3d(obj))
  }
  
  if (!is.null(obj <- x$bbox)) 
    plot3d(obj)
    
  invisible(results)
}      

plot3d.rglobject <- function(x, ...) {
  type <- x$type
  fn <- switch(type,
    points = points3d,
    lines = segments3d,
    linestrip = lines3d,
    triangles = triangles3d,
    quads = quads3d,
    text = texts3d,
    spheres = spheres3d,
    abclines = abclines3d,
    planes = planes3d,
    surface = surface3d,
    sprites = sprites3d,
    NULL)
  if (is.null(fn)) {
    warning("Object type ",type," not handled.")
    return()
  }
  if (!is.null(x$ignoreExtent)) {
    save <- par3d(ignoreExtent = x$ignoreExtent)
    on.exit(par3d(save))
  }
  args <- list()
  args$x <- x$vertices
  args$normals <- x$normals
  args$texcoords <- x$texcoords
  args$texts <- x$texts
  args$cex <- x$cex
  args$adj <- x$adj
  args$radius <- x$radii
  
  switch(type, 
    abclines = {
      odd <- seq_len(nrow(args$x)) %% 2 == 1
      ends <- args$x[odd,,drop=FALSE]
      args$a <- args$x[!odd,,drop=FALSE] - ends
      args$x <- ends
    },
    planes = {
      first <- seq_len(nrow(args$x)) %% 12 == 1
      args$a <- args$normals[first,,drop=FALSE]
      pt <- args$x[first,,drop=FALSE]
      args$d <- numeric(sum(first))
      for (i in seq_along(args$d))
        args$d[i] <- -sum(args$a[i,]*pt[i,])
      args$x <- NULL
      args$normals <- NULL
    },
    surface = {
      dim <- x$dim
      args$y <- matrix(args$x[,2], dim[1], dim[2])
      args$z <- matrix(args$x[,3], dim[1], dim[2])
      args$x <- matrix(args$x[,1], dim[1], dim[2])
      if (!is.null(args$normals)) {
        args$normal_x <- matrix(args$normals[,1], dim[1], dim[2])
	args$normal_y <- matrix(args$normals[,2], dim[1], dim[2])
	args$normal_z <- matrix(args$normals[,3], dim[1], dim[2])
        args$normals <- NULL
      }
      if (!is.null(args$texcoords)) {
        args$texture_s <- matrix(args$texcoords[,1], dim[1], dim[2])
        args$texture_t <- matrix(args$texcoords[,2], dim[1], dim[2])
        args$texcoords <- NULL
      }
    },
    sprites = {
      save2 <- par3d(skipRedraw = TRUE)
      on.exit(par3d(save2), add=TRUE)
  
      if (!is.null(x$objects)) {
        ids <- numeric(length(x$objects))
        for (i in seq_along(ids)) 
          ids[i] <- plot3d(x$objects[[i]])
        args$shapes <- ids
      }
      args$userMatrix <- x$usermatrix
    })
      
  mat <- x$material
  if (is.null(mat)) mat <- list()
  if (!is.null(col <- x$colors)) {
    mat$color <- rgb(col[,1], col[,2], col[,3])
    mat$alpha <- col[,4]
  }
  args <- c(args, mat)
  do.call(fn, args)
}

plot3d.rglbboxdeco <- function(x, ...) {
  # FIXME: can't read these
  args <- list(draw_front = TRUE, front="lines", back="lines")     
  v <- x$vertices
  t <- x$texts
  ind <- is.na(v[,2]) & is.na(v[,3])
  if (any(ind)) {
    args$xat <- v[ind,1]
    if (!is.null(t))
      args$xlab <- t[ind]
  }
  ind <- is.na(v[,1]) & is.na(v[,3])
  if (any(ind)) {
    args$yat <- v[ind,2]
    if (!is.null(t))
      args$ylab <- t[ind]
  }
  ind <- is.na(v[,1]) & is.na(v[,2])
  if (any(ind)) {
    args$zat <- v[ind,3]
    if (!is.null(t))
      args$zlab <- t[ind]
  }
  do.call("bbox3d", args)
}
