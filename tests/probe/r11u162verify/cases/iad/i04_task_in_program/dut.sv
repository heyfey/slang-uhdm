// § implicitArgDimsInner155
program p; task automatic t([5:0] a); $display("%0d", a); endtask initial t(6'd3); endprogram
