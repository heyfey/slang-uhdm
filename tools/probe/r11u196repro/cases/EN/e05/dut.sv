// § classPropElemClassTsAtName196: the element of a class declared in a module and in $unit
class upool #(type T = int); endclass
module top;
  class mpool #(type T = int); endclass
  class holder;
    upool#(byte) u[$];
    mpool#(byte) m[2];
  endclass
  holder h;
endmodule
