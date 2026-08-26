// r10uvm157 grid, arm E — THE NEGATIVE AND BOUNDARY arm.  Every place a
// typedef can be written that is NOT a statement scope (so this law must move
// NOTHING there), every loop / case / always flavour that IS one, and the two
// name-collision shapes r10uvm155's gates care about — asked here of the
// LISTING, which is a different question from the DECLARATION.
// MEASUREMENT ONLY.
typedef bit [1:0] unitLevelPair157;          // e5  a $unit typedef

package Cellar157;
  typedef bit [2:0] cellarPkgTrio157;        // e2  a PACKAGE typedef
  typedef bit [3:0] cellarShared157;         // the collision partner for e8

  class Barrel157;
    typedef bit [4:0] BarrelClassFive157;    // e3  a CLASS typedef
    int stave;
    function void tap();
      // e8  a statement-scope typedef whose bare name is ALSO a PACKAGE
      //     typedef's — r10uvm155 declines the DECLARATION, but the LISTING
      //     is a different question and is asked here
      typedef bit [6:0] cellarShared157;
      cellarShared157 tapVal;
      cellarPkgTrio157 tapPkgVal;
      BarrelClassFive157 tapClsVal;
      tapVal = 0; tapPkgVal = 0; tapClsVal = 0;
    endfunction
  endclass
endpackage

interface Spigot157;                         // e6  an INTERFACE
  typedef bit [7:0] spigotIfaceByte157;      //     ...and its own typedef
  logic drip;
  task pour();                               // e14 an interface TASK body
    typedef bit [8:0] spigotTaskNine157;
    spigotTaskNine157 pourVal;
    pourVal = 0;
  endtask
  initial begin
    typedef bit [9:0] spigotInitTen157;
    spigotInitTen157 initVal;
    initVal = 0;
  end
endinterface

module Vintage157;
  typedef bit [10:0] vintageModuleEleven157; // e1  a MODULE-body typedef
  int cask;
  int rack [0:2];

  // e4  a typedef DIRECTLY in a GENERATE block (a gen scope is not a statement
  //     scope; its listing is a different law's and must not move)
  if (1) begin : Cooper157
    typedef bit [11:0] cooperGenTwelve157;
    cooperGenTwelve157 genVal;
    initial genVal = 0;
  end

  // e9  the loop bodies
  initial begin
    foreach (rack[i]) begin
      typedef bit [12:0] vintageForeach157;
      vintageForeach157 feVal; feVal = 0;
    end
    while (cask == 1) begin
      typedef bit [13:0] vintageWhile157;
      vintageWhile157 whVal; whVal = 0;
    end
    do begin
      typedef bit [14:0] vintageDoWhile157;
      vintageDoWhile157 dwVal; dwVal = 0;
    end while (cask == 2);
    repeat (2) begin
      typedef bit [15:0] vintageRepeat157;
      vintageRepeat157 rpVal; rpVal = 0;
    end
    forever begin
      typedef bit [16:0] vintageForever157;
      vintageForever157 fvVal; fvVal = 0;
      break;
    end
  end

  // e10 the case flavours, including the DEFAULT arm
  initial begin
    case (cask)
      0: begin
        typedef bit [17:0] vintageCaseZero157;
        vintageCaseZero157 c0Val; c0Val = 0;
      end
      default: begin
        typedef bit [18:0] vintageCaseDefault157;
        vintageCaseDefault157 cdVal; cdVal = 0;
      end
    endcase
    casez (cask[1:0])
      2'b0?: begin
        typedef bit [19:0] vintageCasez157;
        vintageCasez157 czVal; czVal = 0;
      end
      default: ;
    endcase
    casex (cask[1:0])
      2'b0x: begin
        typedef bit [20:0] vintageCasex157;
        vintageCasex157 cxVal; cxVal = 0;
      end
      default: ;
    endcase
  end

  // e11 a LABELLED begin with an end label, and a labelled fork
  initial begin : Bunghole157
    typedef bit [21:0] vintageLabelled157;
    vintageLabelled157 lbVal; lbVal = 0;
  end : Bunghole157
  initial fork : Hoop157
    begin
      typedef bit [22:0] vintageForkArm157;
      vintageForkArm157 faVal; faVal = 0;
    end
  join_any : Hoop157

  // e12 the always flavours and `final`
  logic drip157;
  always_ff @(posedge drip157) begin
    typedef bit [23:0] vintageAlwaysFf157;
    vintageAlwaysFf157 ffVal; ffVal = 0;
  end
  always_latch begin
    typedef bit [24:0] vintageAlwaysLatch157;
    vintageAlwaysLatch157 alVal; alVal = 0;
  end
  always @(*) begin
    typedef bit [25:0] vintageAlwaysStar157;
    vintageAlwaysStar157 asVal; asVal = 0;
  end
  final begin
    typedef bit [26:0] vintageFinal157;
    vintageFinal157 fnVal; fnVal = 0;
  end

  // e13 a `begin` whose ONLY content is the typedef — no variable at all
  initial begin
    begin
      typedef bit [27:0] vintageLonelyTd157;
    end
    cask = 0;
  end

  // e15 TWO SIBLING begins declaring the SAME typedef name
  initial begin
    begin
      typedef bit [28:0] vintageTwin157;
      vintageTwin157 twinAVal; twinAVal = 0;
    end
    begin
      typedef logic [29:0] vintageTwin157;
      vintageTwin157 twinBVal; twinBVal = 0;
    end
  end

  Spigot157 spout ();
  initial begin
    Cellar157::Barrel157 b;
    b = new();
    b.tap();
    spout.pour();
  end
endmodule

// e7  a PROGRAM's initial (r10uvm155's carve-out RESOLVES the declaration; the
//     LISTING is asked separately)
program Cork157;
  initial begin
    typedef bit [30:0] corkProgThirtyOne157;
    corkProgThirtyOne157 corkVal;
    corkVal = 0;
  end
endprogram
