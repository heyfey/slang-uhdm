// § streamBraceInMacroBody246
`define PACK_INTN(VAR,SIZE) \
  begin \
   int __array[]; \
   begin \
     bit [SIZE-1:0] __vector = VAR; \
     { << int { __array }} = {{($bits(int) - (SIZE % $bits(int))) {1'b0}}, __vector}; \
   end \
  end
`define UNPACK_INTN(VAR,SIZE) \
   begin \
      int __array[] = new[(SIZE+31)/32]; \
      bit [(((SIZE + 31) / 32) * 32) - 1:0] __var; \
      __var = { << int { __array }}; \
      VAR = __var; \
   end
package p;
  class c;
    bit [63:0] m_address;
    function void f();
      `PACK_INTN(m_address, 64)
    endfunction
    function void g();
      `UNPACK_INTN(m_address, 64)
    endfunction
  endclass
endpackage
module top;
endmodule
