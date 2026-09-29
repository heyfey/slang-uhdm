package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class c;
    function void set(alias_t v); endfunction
  endclass
endpackage
interface ifc;
  import p::*;
endinterface
module m;
  ifc i();
endmodule
