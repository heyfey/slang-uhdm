// § modFnLitLeftoverAtLiteral302
// l11: a module-local struct typedef and a module builder
module dut(output logic o);
  typedef struct packed { logic [15:0] a; logic [15:0] b; } c_t;
  function automatic c_t mk();
    c_t c; c.a = 16'd9; c.b = 3; return c;
  endfunction
  localparam c_t L = mk();
  localparam logic [15:0] LA = L.a;
  assign o = 1'b0;
endmodule
