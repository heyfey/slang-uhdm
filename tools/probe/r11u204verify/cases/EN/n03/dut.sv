// § classPropElemClassTsAtName196: element specializations as module variables, function locals and a class in a module (not a package class property)
package p;
  class pool #(type K = int); K k; endclass
endpackage
module top;
  import p::*;
  pool#(byte) mv[4];
  pool#(int) mq[$];
  class mc;
    pool#(shortint) arr[2];
  endclass
  function automatic int cnt();
    pool#(bit) loc[3];
    return $size(loc);
  endfunction
endmodule
