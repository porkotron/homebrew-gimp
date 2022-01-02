# GeglGimp exists in case a formula for GIMP is ever added.
# GEGL in homebrew-core does not compile with Cairo, which causes
# GIMP to crash at runtime.
# libgimp2.0 works fine with homebrew-core/gegl
# If this formula is enabled, it will need to be kept in sync with homebrew-core/gegl
class GeglGimp < Formula
  desc "Graph based image processing framework"
  homepage "https://www.gegl.org/"
  url "https://download.gimp.org/pub/gegl/0.4/gegl-0.4.32.tar.xz"
  sha256 "668e3c6b9faf75fb00512701c36274ab6f22a8ba05ec62dbf187d34b8d298fa1"

  bottle do
    sha256 mojave:      "b8332d3d8eebb52fd56aa05855c86b41bc3e927bd3b6dd71d548463a61e50684"
    sha256 high_sierra: "123bd45aa0e95f88fd358d658550b1f7ddb2ba67db618a7b211b0de03f998a0d"
    sha256 sierra:      "63631fab75456b433df2fb72701265d5a755795ffaa2d9d30034f7cef5426597"
  end

  head do
    # Use the Github mirror because official git unreliable.
    url "https://github.com/GNOME/gegl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "babl"
  depends_on "cairo"
  depends_on "gettext"
  depends_on "glib"
  depends_on "jpeg"
  depends_on "json-glib"
  depends_on "libpng"
  depends_on "pango"

  conflicts_with "gegl", because: "gegl-gimp is just gegl compiled with extra options required by GIMP"
  conflicts_with "coreutils", because: "both install `gcut` binaries"

  def install
    # This formula is only here for possible future use.
    odie "gegl-gimp is not currently implemented. Use gegl instead."

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-docs",
                          # "--without-cairo",
                          "--without-jasper",
                          "--without-umfpack"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gegl.h>
      gint main(gint argc, gchar **argv) {
        gegl_init(&argc, &argv);
        GeglNode *gegl = gegl_node_new ();
        gegl_exit();
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}/gegl-0.4", "-L#{lib}", "-lgegl-0.4",
           "-I#{Formula["babl"].opt_include}/babl-0.1",
           "-I#{Formula["glib"].opt_include}/glib-2.0",
           "-I#{Formula["glib"].opt_lib}/glib-2.0/include",
           "-L#{Formula["glib"].opt_lib}", "-lgobject-2.0", "-lglib-2.0",
           testpath/"test.c", "-o", testpath/"test"
    system "./test"
  end
end
