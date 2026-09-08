// r10uvm206 grid arm D — NEGATIVE CONTROL: the import is written INSIDE the
// module, so it is NOT a compilation-unit import and the package's class keys
// never join the design's typespec listing.  Byte-for-byte, this arm must read
// the same on the pristine and the patched binary.
package pd206;
  class cd206_self;
    typedef cd206_self this_type;
    int s;
  endclass
  typedef int td206_plain;
endpackage

module gd206;
  import pd206::*;
  cd206_self h0;
  td206_plain w0;
endmodule
