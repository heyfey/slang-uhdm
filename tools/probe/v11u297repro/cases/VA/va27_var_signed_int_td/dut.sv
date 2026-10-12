// § varDeclInitElabSpan297
typedef logic signed [3:0] s_t;
typedef enum int { X0 = 3, X1 } ie_t;
module dut(output logic [3:0] o, output int p);
  var s_t x = -4'sd2;
  var ie_t y = X1;
  assign o = x;
  assign p = y;
endmodule
