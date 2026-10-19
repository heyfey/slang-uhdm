class D; extern function new(); endclass
`include "inner.svh"
function B::new(); int bb; bb = 1; endfunction
