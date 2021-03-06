\name{par3d}
\alias{par3d}
\alias{open3d}
\alias{r3dDefaults}
\alias{getr3dDefaults}
\concept{FOV}
\concept{modelMatrix}
\concept{mouseMode}
\concept{projMatrix}
\concept{scale}
\concept{userMatrix}
\concept{viewport}
\concept{zoom}
\concept{bbox}

\title{Set or Query RGL Parameters}

\description{
  \code{par3d} can be used to set or query graphical parameters in rgl.
  Parameters can be set by specifying them as arguments to \code{par3d} in
  \code{tag = value} form, or by passing them as a list of tagged
  values.
}
\usage{
par3d(\dots, no.readonly = FALSE)

open3d(\dots, params=getr3dDefaults(), 
	    useNULL = rgl.useNULL())
	    
getr3dDefaults()
}

\arguments{
  \item{\dots}{arguments in \code{tag = value} form, or a list of tagged
    values.  The tags must come from the graphical parameters described
    below.}
  \item{no.readonly}{logical; if \code{TRUE} and there are no other
    arguments, only those parameters which can be set by a
    subsequent \code{par3d()} call are returned.}
  \item{params}{a list of graphical parameters}
  \item{useNULL}{whether to use the null graphics device}
}

\details{
  Parameters are queried by giving one or more character vectors to
  \code{par3d}.

  \code{par3d()} (no arguments) or \code{par3d(no.readonly=TRUE)} is used to
  get \emph{all} the graphical parameters (as a named list).  

  \emph{\bold{R.O.}} indicates \emph{\bold{read-only arguments}}: These
  may only be used in queries, i.e., they do \emph{not} set anything.

  \code{open3d} opens a new rgl device, and sets the parameters as
  requested.  The \code{r3dDefaults} list returned by the 
  \code{getr3dDefaults} function will be used as default
  values for parameters.  As installed this sets the point of view to
  'world coordinates' (i.e. x running from left to right, y from front
  to back, z from bottom to top), the \code{mouseMode} to
  \code{(zAxis, zoom, fov)}, and the field of view to 30 degrees.
  Users may create their own variable named \code{r3dDefaults} in the global
  environment and it will override the installed one.  If there
  is a \code{bg} element in the list or the arguments, it should be
  a list of arguments to pass to the \code{\link{bg3d}} function to 
  set the background.  
  
  The arguments to \code{open3d} may include \code{material}, a list
  of material properties as in \code{\link{r3dDefaults}}, but note
  that high level functions such as \code{\link{plot3d}} normally use
  the \code{r3dDefaults} values in preference to this setting. 
  
  If \code{useNULL} is \code{TRUE}, \pkg{rgl} will use a \dQuote{null}
  device.  This device records objects as they are plotted, but 
  displays nothing. It is intended for use with \code{\link{writeWebGL}}
  and similar functions.
}

\value{
  When parameters are set, their former values are returned in an
  invisible named list.  Such a list can be passed as an argument to
  \code{par3d} to restore the parameter values.
  Use \code{par3d(no.readonly = TRUE)} for the full list of parameters
  that can be restored.

  When just one parameter is queried, its value is returned directly.
  When two or more parameters are queried, the result is a list of
  values, with the list names giving the parameters.

  Note the inconsistency: setting one parameter returns a list, but
  querying one parameter returns an object.
}

\section{Parameters}{
  \describe{
    \item{\code{antialias}}{\emph{\bold{R.O}} in \code{par3d}, may be
    set in \code{open3d}. The (requested) number of hardware
    antialiasing planes to use (with multisample antialiasing).  The
    OpenGL driver may not support the requested number, in which case
    \code{par3d("antialias")} will report what was actually set. }    
    \item{\code{cex}}{real.  The default size for text.}
    \item{\code{family}}{character.  The default device independent family name; see \code{\link{text3d}}.}
    \item{\code{font}}{integer.  The default font number (from 1 to 5; see \code{\link{text3d}}.}
    \item{\code{useFreeType}}{logical.  Should FreeType fonts be used?}
    \item{\code{fontname}}{\emph{\bold{R.O.}}; the system-dependent name of the current font.}
    \item{\code{FOV}}{real.  The field of view, from 1 to 179 degrees.  This controls
      the degree of parallax in the perspective view.
      Isometric perspective (which would
      correspond to \code{FOV=0}) is not currently possible, but one can
      approximate it by specifying \code{par3d(FOV=1)}.}
    \item{\code{ignoreExtent}}{logical.  Set to \code{TRUE} so that subsequently plotted objects
      will be ignored in calculating the bounding box of the scene.}
    \item{\code{modelMatrix}}{\emph{\bold{R.O.}}; a 4 by 4 matrix describing the position
      of the user data.}
    \item{\code{mouseMode}}{character.  A vector of 3 strings describing
      what the 3 mouse buttons do. Partial matching is used.  Possible values for \code{mouseMode} are 
	\describe{
	 \item{\code{"none"}}{No action for this button.}
	 \item{\code{"trackball"}}{Mouse acts as a virtual trackball, rotating the scene.}
	 \item{\code{"xAxis"}}{Similar to \code{"trackball"}, but restricted to X axis rotation.}
	 \item{\code{"yAxis"}}{Y axis rotation.}
	 \item{\code{"zAxis"}}{Z axis rotation.}
	 \item{\code{"polar"}}{Mouse rotates the scene by moving in polar coordinates.}
	 \item{\code{"selecting"}}{Mouse is used for selection.  This is not normally set by the
	 user, but is used internally by the \code{\link{select3d}} function.}
	 \item{\code{"zoom"}}{Mouse is used to zoom the display.}
	 \item{\code{"fov"}}{Mouse changes the field of view of the display.}
	 \item{\code{"user"}}{Used  when a user handler is set by 
	 \code{\link{rgl.setMouseCallbacks}}.}
	}
    }
    \item{\code{projMatrix}}{\emph{\bold{R.O.}}; a 4 by 4 matrix describing the current
      projection of the scene.}
    \item{\code{scale}}{real.  A vector of 3 values indicating the amount by which to
      rescale each axis before display.  Set by \code{\link{aspect3d}}.}
    \item{\code{skipRedraw}}{whether to update the display.  Set to \code{TRUE} to suspend
      updating while making multiple changes to the scene.  See \code{demo(hist3d)} for an example.}
    \item{\code{userMatrix}}{a 4 by 4 matrix describing user actions to
      display the scene.}
    \item{\code{viewport}}{\emph{\bold{R.O.}}; real.  A vector giving the dimensions of the
      window in pixels.}
    \item{\code{zoom}}{real. A positive value indicating the current
      magnification of the scene.}
      \item{\code{bbox}}{\emph{\bold{R.O.}}; real. A vector of six values indicating the current values of the
      bounding box of the scene (xmin, xmax, ymin, ymax, zmin, zmax)}
    \item{\code{windowRect}}{integer.  A vector of four values indicating the left, top, right and 
      bottom of the displayed window (in pixels).}
  }
}

\section{note}{
The \code{"xAxis"}, \code{"yAxis"} and \code{"zAxis"} mouse modes rotate relative to the coordinate
system of the data, regardless of the current orientation of the scene.
}

\section{Rendering}{
The parameters returned by \code{par3d} are sufficient to determine where rgl would render
a point on the screen.  Given a column vector \code{(x,y,z)}, it performs the equivalent of 
the following operations:
\enumerate{
\item It converts the point to homogeneous coordinates by appending \code{w=1}, giving
the vector \code{v = (x,y,z,1)}.
\item It calculates the \code{M = par3d("modelMatrix")} as a product from right to left
of the following matrices:
  \itemize{  
  \item A matrix to translate the centre of the bounding box to the origin.
  \item A matrix to rescale according to \code{par3d("scale")}.
  \item The \code{par3d("userMatrix")} as set by the user.
  \item A matrix which may be set by mouse movements.
  \item A matrix to translate the origin to the centre of the viewing region.
  }
\item It multiplies the point by \code{M} giving \code{u = M \%*\% v}.  Using this location and information on the
normals (which have been similarly transformed), it performs lighting calculations. 
\item It obtains the projection matrix \code{P = par3d("projMatrix")} and
multiplies the point by it giving \code{P \%*\% u = (x2, y2, z2, w2)}.
\item It converts back to Euclidean coordinates by dividing the first 3 coordinates by \code{w2}.
\item The new value \code{z2/w2} represents the depth into the scene of the point.  Depending
on what has already been plotted, this depth might be obscured, in which case nothing more is plotted.
\item If the point is not culled due to depth, the \code{x2} and \code{y2} values are used
to determine the point in the image.  The \code{par3d("viewport")} values are used to translate
from the range \code{(-1, 1)} to pixel locations, and the point is plotted.
\item If hardware antialiasing is enabled, then the whole process is
repeated multiple times (at least conceptually) with different
locations in each pixel sampled to determine what is plotted there,
and then the images are combined into what is displayed.
}
See ?\link{matrices} for more information on homogeneous and Euclidean coordinates.
}

\seealso{
\code{\link{rgl.viewpoint}} to set \code{FOV} and \code{zoom}.

\code{\link{rgl.useNULL}} for default usage of null device.
}

\references{
OpenGL Architecture Review Board (1997).  OpenGL Programming Guide.  Addison-Wesley.
}

\examples{
    r3dDefaults
    open3d()
    shade3d(cube3d(color=rep(rainbow(6),rep(4,6))))
    save <- par3d(userMatrix = rotationMatrix(90*pi/180, 1,0,0))
    save
    par3d("userMatrix")    
    par3d(save)
    par3d("userMatrix")
}

\keyword{dynamic}
