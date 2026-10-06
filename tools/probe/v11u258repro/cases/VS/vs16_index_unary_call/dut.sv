// § lvStreamBaseKeepsActual258 (a stream target whose index is a unary operation on a function call)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif bit_field_if); logic x; logic [2:0] k;
  function automatic logic [2:0] fi(input logic [2:0] a); return a; endfunction
  always_comb {>>{bit_field_if.read_data[~fi(k)]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
