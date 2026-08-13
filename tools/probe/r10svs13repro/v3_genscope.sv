// r10svs13 VERIFIER arm v3 — the campaign's classic blind spot: a PROGRAM with an
// interface-ARRAY port instantiated inside a GENERATE scope (genvarConnFold armed),
// and inside an if-generate.  Module twins are the controls.
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, output d);
endinterface
program leafGp(oif.OP a[4], oif.OP b);
endprogram
module  leafGm(oif.OP a[4], oif.OP b);
endmodule

module top();
bit Clock;
oif arr[4](Clock);
oif sc(Clock);
for (genvar i = 0; i < 2; i++) begin : gblk
  leafGp gp(arr, sc);
  leafGm gm(arr, sc);
end
if (1) begin : iblk
  leafGp ip(arr, sc);
  leafGm im(arr, sc);
end
endmodule
