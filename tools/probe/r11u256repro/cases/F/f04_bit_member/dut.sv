// § patLitFormFileAtRef256 (a one-bit member read from the package (the BIN literal form))
typedef struct packed { logic en; logic [3:0] cnt; } c_t;
module top(output logic [4:0] o);
  localparam c_t C = '{en: dm::XF, cnt: dm::DataCount};
  assign o = C;
endmodule
