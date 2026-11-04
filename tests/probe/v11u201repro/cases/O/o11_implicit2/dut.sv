// § opCtxBindableTarget201v
module sub(input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign n1 = f(a) & 4'd1;
  assign n2 = ~f(a);
  assign o = {n1, n2, 2'b0};
endmodule
module top(input logic [3:0] a, output logic [3:0] o);
  sub u(.a(a), .o(o));
endmodule
