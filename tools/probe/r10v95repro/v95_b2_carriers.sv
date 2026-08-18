// r10v95 arm b2 — the same select-bearing $bits in EVERY CARRIER.
module b2 #(parameter int GP = 4) ();
  bit [23:0] sig24;
  byte       bar [5];
  byte       flex [];
  logic [15:0] pkq [2];

  localparam int LP1 = $bits(sig24[3]);         // param init
  localparam int LP2 = $bits(bar[1]);
  localparam int LP3 = $bits(flex[0]);

  wire [$bits(sig24[7:0])-1:0] rngnet;          // range bound
  logic [$bits(bar[2])+1:0] rngvar;

  int acc;
  int sel;
  initial begin
    if ($bits(sig24[2]) > 8) acc = 1;           // if condition
    acc = $bits(sig24[2]) + $bits(bar[3]);      // operation
    acc = int'($bits(flex[1]));                 // cast
    acc = $bits(pkq[0][3:0]);                   // assignment rhs
    $display("%0d", $bits(bar[4]));             // call arg
    case (sel)
      $bits(sig24[1]): acc = 2;                 // case item
      $bits(flex[2]): acc = 3;
      default: acc = 4;
    endcase
    acc = {>>{ sig24 }};
  end
  generate
    if ($bits(bar[0]) == 8) begin : g_yes
      localparam int GIN = $bits(pkq[1][7:4]);
    end
  endgenerate
endmodule
