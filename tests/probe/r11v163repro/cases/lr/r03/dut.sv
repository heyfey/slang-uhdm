// § ovPatOpCopyAtLocalRef163v
typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
interface ti #(parameter P = '0)(); logic [4:0] q; assign q = P; endinterface
module dut();
  localparam r_t L = '{a: 2'b10, b: 3'd5};
  ti #(.P(L)) t();
endmodule
