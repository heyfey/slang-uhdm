// § leftoverTsCopyPerElabUse272
// a packed-array member written whole and element by element
package pk;
  typedef struct packed { logic [3:0][7:0] arr; logic [7:0] x; } c_t;
  localparam logic [3:0][7:0] AR = {8'd1, 8'd2, 8'd3, 8'd4};
  function automatic c_t mk();
    c_t c; c.arr = AR; c.x = 8'd9; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic o);
  localparam int unsigned RD = P.arr[1];
  assign o = '0;
endmodule
module dut(output logic o); kid k0 (.o(o)); endmodule
