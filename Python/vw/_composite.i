%module composite
%import "_image.i"

%{
#include <vw/Image.h>
#include <vw/Mosaic.h>
%}

namespace vw {
namespace mosaic {

  template <class PixelT>
  class ImageComposite {
  public:
    ImageComposite();


    void prepare();
    void prepare( vw::BBox2i const& total_bbox );

    void set_draft_mode( bool draft_mode );

    %extend {
      int get_cols() const { return self->cols(); }
      int get_rows() const { return self->rows(); }
      int get_planes() const { return self->planes(); }
      int get_channels() const { return self->channels(); }
      vw::BBox2i const& get_bbox() const { return self->bbox(); }
      vw::BBox2i const& get_source_data_bbox() const { return self->source_data_bbox(); }
      vw::ImageViewRef<PixelT> ref() const { return *self; }

      void _insert( vw::ImageViewRef<PixelT> const& image, int x, int y ) { self->insert(image,x,y); }
    }

    %pythoncode {
      cols = property(get_cols)
      rows = property(get_rows)
      planes = property(get_planes)
      channels = property(get_channels)
      bbox = property(get_bbox)
      source_data_bbox = property(get_source_data_bbox)
      draft_mode = property(fset=set_draft_mode)

      def insert(self, image, x, y):
        self._insert(image.ref(),x,y)
    }

  };

} // namespace mosaic
} // namespace vw

%pythoncode {

  class ImageComposite(object):

    _pixel_type_table = dict()

    def ImageComposite(ptype=None, pformat=None, ctype=None, **args):
      ptype = pixel._compute_pixel_type(pixel.PixelRGBA_float32,ptype,pformat,ctype);
      return self._pixel_type_table[ptype](args)

}

%define %instantiate_imagecomposite_types(cname,ctype,pname,ptype,...)
  %template(ImageComposite_##pname) vw::mosaic::ImageComposite<ptype >;
  %pythoncode {
    ImageComposite._pixel_type_table[pixel.pname] = ImageComposite_##pname
    ImageComposite_##pname.pixel_type = pixel.pname
    ImageComposite_##pname.channel_type = pixel.cname
  }
%enddef

%instantiate_for_pixel_types(instantiate_imagecomposite_types)
