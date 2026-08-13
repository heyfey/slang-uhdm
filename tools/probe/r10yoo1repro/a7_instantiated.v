// r10yoo1 ARM a7 -- THE INSTANTIATION CONFOUND.
//
// Arm a6 cell z5 contradicted the ablation table at src/ParamEmit.cpp:13993
// (`whole name in a ternary condition -> LOCATED`) using the table's OWN
// parameter shape.  But that table's probes are described as "one instantiated
// `sub`", and every module in arms a1-a6 is UNINSTANTIATED.  An uninstantiated
// module's elaborated row and an instantiated one's are different objects
// reached by different paths, so the contradiction is only real if it survives
// instantiation.  This arm settles it instead of asserting it.
//
// Each cell appears TWICE in the census: once as its own uninstantiated
// top-module row (`work@k?_child`) and once as an instance row
// (`work@k?_parent.u?`).  Both are read.
//
// k1  the table's shape, INSTANTIATED       `parameter [4:0] P = 7` in a cond
// k2  the witness's shape, INSTANTIATED     untyped sized literal, both branches
// k3  the witness's shape with an OVERRIDE   isOverriddenParam is an explicit
//                                           gate in the production condition, so
//                                           an overridden param must be shown
//                                           NOT to move

module k1_child;
   parameter [4:0] P1 = 7;
   wire [4:0] np1, np2;
   wire [4:0] o1;
   assign o1 = P1 ? np1 : np2;
endmodule

module k1_parent;
   k1_child u1 ();
endmodule

module k2_child;
   parameter Q1 = 31'h7f800000,
	     Q2 = 31'h7fc00001;
   wire n1, n2;
   wire [30:0] o2;
   assign o2 = (n1 | n2) ? Q2 : Q1;
endmodule

module k2_parent;
   k2_child u2 ();
endmodule

module k3_child;
   parameter R1 = 31'h7f800000,
	     R2 = 31'h7fc00001;
   wire n1, n2;
   wire [30:0] o3;
   assign o3 = (n1 | n2) ? R2 : R1;
endmodule

module k3_parent;
   k3_child #(31'h7f800002, 31'h7f800003) u3 ();
endmodule
