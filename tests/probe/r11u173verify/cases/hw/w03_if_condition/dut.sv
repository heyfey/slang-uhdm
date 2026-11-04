// § hpDotWsTrimmed167 — blanks around the dot in a procedural if condition
interface bif;
  logic en;
  logic [7:0] wdtxx;
endinterface
module top (input logic en, input logic [7:0] a, output logic [7:0] y);
  bif bs();
  assign bs.en = en;
  assign bs.wdtxx = a;
  always_comb begin
    if (bs  .  en) y = bs.wdtxx;
    else y = '0;
  end
endmodule
