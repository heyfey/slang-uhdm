module neg_child102 #(parameter P = 'b101) ();
endmodule

module neg102;
  localparam signed NS = 'b101;
  localparam unsigned NU = 'h1a;
  localparam [7:0] NR = 'o17;
  localparam NX = 'bx;

  function automatic int f102;
    localparam NF = 'b101;
    return NF;
  endfunction

  neg_child102 #(.P('h2a)) u();
endmodule
