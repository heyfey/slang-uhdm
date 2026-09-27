// § rootPathFullNameByChain181 (v11u181 break: $root in two top modules, a nested module instance reading upward, a macro-defined path)
`define RP $root.top2.x
module leaf; logic l; always_comb l = $root.top.m.v; endmodule
module mid; logic v; leaf lf(); endmodule
module top; mid m(); logic z; assign z = `RP; endmodule
module top2; logic x; endmodule
