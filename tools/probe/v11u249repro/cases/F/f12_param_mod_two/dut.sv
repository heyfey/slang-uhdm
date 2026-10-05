// § modTdElabFoldSize249 (control: the law does not fire)
module sub #(parameter W = 2);
  typedef logic [W-1:0] f_t[3];
  f_t x;
endmodule
module top; sub #(4) a(); sub #(8) b(); endmodule
