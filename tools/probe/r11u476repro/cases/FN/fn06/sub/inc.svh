module m;
  initial `SHOW("a");
  initial $display(`__FILE__, "b", `__LINE__);
endmodule
