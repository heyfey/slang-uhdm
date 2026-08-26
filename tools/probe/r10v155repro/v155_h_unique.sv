// p5 — the UNIQUENESS gate's reach.  `bindTypedefs_` repairs a placeholder only
// from a typedef registered in the SAME DesignComponent as the declaration
// (ElaborationStep.cpp:302-320, the inner loop is comp->getLateTypedefBinding()),
// but the pass declines on ANY same-named typedef in the design's syntax.
module mOwner155v;
  // an UNRELATED module owns a registered typedef of the same bare name
  typedef int strangerTd155v;
  strangerTd155v ownerVar155v;
  initial ownerVar155v = 1;
endmodule

module mUser155v;                    // a DIFFERENT component
  initial begin
    typedef byte strangerTd155v;     // same bare name, different component
    strangerTd155v userVal155v;      // golden: ? ; ours: ?
    userVal155v = 8'd2;
  end
endmodule

// The SAME-component collision, for contrast.
module mSelf155v;
  typedef int selfTd155v;
  selfTd155v selfOuter155v;
  initial begin
    typedef byte selfTd155v;
    selfTd155v selfVal155v;
    selfVal155v = 8'd3;
  end
  initial selfOuter155v = 4;
endmodule

// A FORWARD typedef declared inside a statement scope.
module mFwdBlk155v;
  initial begin
    typedef fwdInBlk155v;
    typedef bit [4:0] fwdInBlk155v;
    fwdInBlk155v fwdBlkVal155v;
    fwdBlkVal155v = 5'd5;
  end
endmodule

// A statement-scope typedef used TWICE in the same block (two declarations).
module mTwice155v;
  initial begin
    typedef byte twiceTd155v;
    twiceTd155v twiceA155v;
    twiceTd155v twiceB155v;
    twiceA155v = 8'd6;
    twiceB155v = 8'd7;
  end
endmodule
