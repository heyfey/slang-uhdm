interface e05if #(parameter IW = 'b101) ();
  localparam IL = 'h1a;
  logic [IW-1:0] d;
  modport mp (input d);
endinterface
module e05 (e05if.mp p);
endmodule
module e05top;
  e05if #(.IW('h4)) i0();
  e05if i1();
  e05 u0(.p(i0.mp));
endmodule
