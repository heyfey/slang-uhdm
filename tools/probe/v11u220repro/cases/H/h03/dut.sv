// § lvIdxPathRangeTailIsRead218
typedef struct packed { logic [6:0] addr; logic [31:0] data; } req_t;
module top(input req_t req, output logic [3:0][3:0][7:0] o);
  always_comb begin
    o = '0;
    o[req.addr[1:0]][req.addr[3:2]] = req.data[7:0];
  end
endmodule
