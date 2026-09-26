`define MUL(a, b) ((a) * (b))
`define ADD(a, b) ((a) + (b))
assign y = `ADD(`MUL(a,
                     b), c);
assign z = c[0];
