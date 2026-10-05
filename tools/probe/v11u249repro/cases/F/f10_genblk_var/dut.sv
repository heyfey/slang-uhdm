// § modTdElabFoldSize249
module top #(parameter G = 1);
  typedef int f_t[4];
  if (G) begin : g
    f_t x;
  end
  f_t y;
endmodule
