// v99 b3 — THE FENCE: range-free sets everywhere, plus case-inside, dist,
// covergroup bins and constraints.  NOTHING here may move.
module mub3 (input logic ckb3);
  int  fb31, fb32, fb33, fb34, fb35, fb36, fb37;
  int  fqb3 [$];
  int  fab3 [3];
  logic ob31, ob32;
  string sb3;
  typedef enum int { GA3 = 2, GB3 = 5 } eb3;
  eb3 eb31;

  assign ob31 = fb31 inside {1, 2, 3};
  always_comb ob32 = fb32 inside {fab3};
  always @(*) begin
    if (fb33 inside {7})            fb34 = 1;
    if (fb34 inside {fqb3})         fb35 = 2;
    if (sb3  inside {"pp", "qq"})   fb36 = 3;
    if (eb31 inside {GA3, GB3})     fb37 = 4;
    if (fb35 inside {fb36, fb37})   fb31 = 5;
    if ((fb36 + fb37) inside {9})   fb32 = 6;
  end
  function automatic int fnb3(int xb3);
    return (xb3 inside {11, 12}) ? 1 : 0;
  endfunction
  initial begin
    int rb3 [$];
    rb3 = fqb3.find(ivb3) with (ivb3 inside {3, 4, 5});
  end

  // case-inside: a DIFFERENT emission path, must not move
  always @(*) begin
    case (fb31) inside
      [1:3]      : fb32 = 1;
      4, [6:8]   : fb32 = 2;
      9          : fb32 = 3;
      default    : fb32 = 0;
    endcase
  end

  // covergroup bins with ranges
  covergroup cgb3 @(posedge ckb3);
    cpb3 : coverpoint fb31 {
      bins lob3 = {[0:3]};
      bins hib3 = {4, [5:7]};
    }
  endgroup
endmodule

class clb3;
  rand int rb31, rb32;
  constraint kb31 { rb31 inside {1, 2, 3}; }
  constraint kb32 { rb32 dist { [1:3] := 1, 5 := 2 }; }
endclass
