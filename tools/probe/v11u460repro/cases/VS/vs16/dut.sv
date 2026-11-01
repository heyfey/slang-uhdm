// § specGroupAliasFlatRoot460 (three typedefs in the home package, the importer reached by a module)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  typedef S #(item) b_t;
  typedef S #(item) c_t;
  typedef S #(item) d_t;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
module top;
  import u::*;
  import a::*;
  a_seqr h; b_t x; c_t y; d_t z;
  initial h = new;
endmodule
