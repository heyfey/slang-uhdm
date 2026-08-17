interface inner #(parameter int AW = 16);
  logic [AW-1:0] ia;
  modport mp (input ia);
endinterface
interface outer #(parameter int AW = 16);
  logic [AW-1:0] oa;
  inner #(AW) ui();
  modport mp (input oa);
endinterface
module recv #(parameter int AW = 5)(outer.mp p[3]);
endmodule
module top;
  outer #(8) arr[3]();
  recv u (.p(arr));
endmodule
