// r10v157 ARM B — TARGET FORMS THE IMPLEMENTER'S b_form DID NOT WRITE.
// One `begin` per form so a decline can never be confused with a neighbour.
// MEASUREMENT ONLY.
interface Loom157;
  logic strand157;
endinterface

class Bramble157;
  int thorn157;
endclass

module Trellis157 #(parameter int VINE157 = 9) ();
  localparam int ARBOR157 = 5;
  typedef bit [3:0] outerLeaf157;          // an OUTER typedef, shadowed below

  initial begin : b_multidim157
    // MULTI-DIMENSIONAL PACKED target — two ranges on one typespec
    typedef bit [3:0][7:0] rungGrid157;
    rungGrid157 rungHold157;
    rungHold157 = 0;
  end

  initial begin : b_regword157
    // the `reg` spelling of a vector
    typedef reg [6:0] pegBar157;
    pegBar157 pegHold157;
    pegHold157 = 0;
  end

  initial begin : b_clog157
    // a $clog2 bound — a SYSTEM FUNCTION that is NOT $bits
    typedef bit [$clog2(VINE157)-1:0] clogSpan157;
    clogSpan157 clogHold157;
    clogHold157 = 0;
  end

  initial begin : b_paramrange157
    // a LOCALPARAM bound (a ref_obj operand, not a sys_func_call)
    typedef logic [ARBOR157-1:0] arborSpan157;
    arborSpan157 arborHold157;
    arborHold157 = 0;
  end

  initial begin : b_signed157
    // an explicitly SIGNED vector and an explicitly UNSIGNED atom
    typedef bit signed [7:0] tallySigned157;
    typedef byte unsigned tallyByteU157;
    tallySigned157 ts157; tallyByteU157 tb157;
    ts157 = 0; tb157 = 0;
  end

  initial begin : b_eventchandle157
    // the two non-arithmetic atoms
    typedef event knockEvt157;
    typedef chandle graspPtr157;
    knockEvt157 ke157; graspPtr157 gp157;
    gp157 = null;
  end

  initial begin : b_shadow157
    // a statement-scope typedef that SHADOWS a module typedef of the SAME NAME
    // with a DIFFERENT width — the name must not resolve to the outer object
    typedef bit [15:0] outerLeaf157;
    outerLeaf157 shadowHold157;
    shadowHold157 = 0;
  end

  initial begin : b_lateuse157
    // a typedef declared AFTER a variable of an EARLIER typedef: the listing
    // ORDER is declaration order, and both are listed
    typedef bit [2:0] firstCut157;
    firstCut157 firstHold157;
    typedef bit [12:0] secondCut157;
    secondCut157 secondHold157;
    firstHold157 = 0; secondHold157 = 0;
  end

  initial begin : b_realtime157
    typedef real gaugeReal157;
    typedef realtime gaugeRT157;
    typedef time gaugeTime157;
    gaugeReal157 gr157; gaugeRT157 grt157; gaugeTime157 gt157;
    gr157 = 0.0; grt157 = 0.0; gt157 = 0;
  end

  initial begin : b_nameonly157
    // NAME targets only — nothing is pushed, so the scope must stay null
    typedef outerLeaf157 aliasLeaf157;
    typedef Bramble157 aliasCls157;
    typedef virtual Loom157 aliasVif157;
    aliasLeaf157 al157;
    al157 = 0;
  end

  initial begin : b_forward157
    // a FORWARD typedef followed by its own definition in the SAME scope
    typedef fernRoot157;
    typedef bit [8:0] fernRoot157;
    fernRoot157 fernHold157;
    fernHold157 = 0;
  end
endmodule
