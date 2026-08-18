// vrgg17 v7 — NEGATIVE / EXTREME index values and out-of-order arrays, to
// stress `std::to_string` and the INT:/UINT: encoding of the folded constant.
interface sif; logic [31:0] value; endinterface
module sink (input logic [3:0] d); endmodule
module top;
  sif arr[0:31]();
  sif neg[-4:4]();               // NEGATIVE lower bound
  for (genvar i = 1; i < 3; i++) begin : g
    sink u_n1 (.d(neg[-4+i].value[0+:4]));      // element slot is NEGATIVE
    sink u_n2 (.d(neg[i-4].value[0+:4]));       // ditto, minus form
    sink u_n3 (.d(arr[2*i-1].value[2*i-2+:2])); // ips base 0,2 via minus
    sink u_n4 (.d(arr[31-i].value[0+:4]));      // top of the range
  end
endmodule
