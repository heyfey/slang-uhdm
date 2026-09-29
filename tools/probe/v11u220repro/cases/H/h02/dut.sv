// § lvIdxPathRangeTailIsRead218
typedef struct packed { logic [6:0] addr; logic [31:0] data; } req_t;
module top(input req_t req, input logic [1:0] k, output logic [3:0][31:0] o);
  always_comb begin
    o = '0;
    o[req.addr[k+:2]] = req.data;
  end
endmodule
