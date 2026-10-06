// § cloneMemberImporterListing259 (a local in a foreach begin block, as uvm_hdl_concat2string)
package p;
  typedef struct { string path; int offset; } slice_t;
  function automatic string f();
    string image = "{";
    slice_t arr[2];
    foreach (arr[i]) begin
      slice_t slice = arr[i];
      image = {image, slice.path};
    end
    return image;
  endfunction
endpackage
package q;
  import p::*;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc u();
endmodule
