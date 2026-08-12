// r10svs9 VERIFIER arm v1 — EMPTY PRODUCT CELLS: the OTHER CONTEXTS that route
// through emitEventExpr.  The implementer's grid (a1..a4) measures only the
// STATEMENT / always-block event control (StmtEmit.cpp:937).  emitEventExpr has
// SIX other call sites (ModuleEmit.cpp:1402, 21029, 21034, 21162, 21244, 21396;
// ExprEmit.cpp:16574, 16583, 16752), and § parensLessEventPathBaseRef9 fires at
// ALL of them because its predicate reads only the TimingControl.
//
//   k1  clocking-block DECLARATION with a parens-less dotted event  (21162/21244)
//   k2  its parenthesized twin                                       (control)
//   k3  named property's clocking event, parens-less dotted          (21029/21034)
//   k4  its parenthesized twin                                       (control)
//   k5  inline assert property (@ a.b …)                             (21029)
//   k6  named sequence's clocking event                              (21396)
//
// The FULLNAME is the thing at risk here: at those sites the `prefix` argument
// is the CLOCKING BLOCK's fullname (`cbFull`) or the ASSERTION's (`aprefix`),
// NOT the enclosing scope's, and the law computes vpiFullName as
// joinRef(prefix, base).
interface in_if(input bit clock);
    logic rdy;
    clocking cb @(posedge clock);
        input rdy;
    endclocking
    modport IP(clocking cb, input clock, input rdy);
endinterface

module top;
    bit clock;
    in_if u_if(clock);

    // k1 — clocking block declaration, PARENS-LESS dotted event
    clocking cb2 @ u_if.clock;
        input rdy = u_if.rdy;
    endclocking

    // k2 — its PARENTHESIZED twin (control)
    clocking cb3 @(u_if.clock);
        input rdy = u_if.rdy;
    endclocking

    // k3 — named property, PARENS-LESS dotted clocking event
    property p1;
        @ u_if.clock u_if.rdy;
    endproperty
    ap1: assert property (p1);

    // k4 — its PARENTHESIZED twin (control)
    property p2;
        @(u_if.clock) u_if.rdy;
    endproperty
    ap2: assert property (p2);

    // k5 — INLINE assert property with a parens-less dotted clocking event
    ap3: assert property (@ u_if.clock u_if.rdy);

    // k6 — named sequence, PARENS-LESS dotted clocking event
    sequence s1;
        @ u_if.clock u_if.rdy;
    endsequence
    ap4: assert property (s1);
endmodule
