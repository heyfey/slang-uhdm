// r10svs9 VERIFIER arm v4 — the remaining EMPTY PRODUCT CELLS.
//
//   n1  always_ff  @ u_if.clock        (the grid only measures plain `always`)
//   n2  always_latch @ u_if.clock
//   n3  base is a GENERATE BLOCK NAME, not a variable: @ g.gst — the collapsed
//       ref_obj would then be named for a SCOPE, which is a different thing to
//       be right about than a variable
//   n4  THREE components where the FIRST is a generate block: @ g.gst.f
//   n5  inside an UNNAMED begin/end (prefix formation with no block name)
//   n6  inside a PROGRAM block
//   n7  inside a FORK/JOIN
//   n8  inside a nested named block: @ st.f under `begin : nb`
package pk;
    typedef struct packed { logic f; logic g; } st_t;
endpackage

interface in_if(input bit clock);
    logic rdy;
    modport IP(input clock, input rdy);
endinterface

module top;
    bit clock;
    in_if u_if(clock);
    pk::st_t st;

    // n1 / n2 — the other always flavours
    always_ff @ u_if.clock begin
    end
    // n2 — REMOVED: slang rejects a time-passing statement in always_latch
    // ("statements that pass time are not allowed in this context"), so the
    // cell cannot be measured on our side.  Recorded, not smoothed over.

    if (1) begin : g
        pk::st_t gst;
    end

    // n3 — the BASE is a GENERATE BLOCK NAME
    always @ g.gst begin
    end
    always @(g.gst) begin
    end

    // n4 — three components, the first a generate block
    always @ g.gst.f begin
    end
    always @(g.gst.f) begin
    end

    // n5 — unnamed begin/end
    initial begin
        begin
            @ st.f;
        end
    end

    // n7 — fork/join
    initial fork
        @ st.f;
    join

    // n8 — nested NAMED block
    initial begin : nb
        @ st.f;
    end
endmodule

// n6 — PROGRAM block scope
program pgm;
    pk::st_t pst;
    initial begin
        @ pst.f;
    end
    initial begin
        @(pst.f);
    end
endprogram
