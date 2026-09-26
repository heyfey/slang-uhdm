// § defGenPathSel161 — gen-case condition over an interface port's struct-parameter member, the items targeting the port
interface c_if #(parameter struct packed { logic [1:0] m; logic [1:0] n; } C = '{m: 2'd1, n: 2'd2});
  logic [3:0] d;
endinterface
module sub(c_if b);
  case (b.C.m)
    2'd1: begin : one
      assign b.d = 4'd1;
    end
    default: begin : other
      assign b.d = 4'd0;
    end
  endcase
endmodule
module top(output logic [3:0] o);
  c_if x();
  sub u(.b(x));
  assign o = x.d;
endmodule
