// r10svs12 arm d4 — ESCAPED IDENTIFIERS on the broadcast-port cells.
//
// The ops rules require an escaped-identifier arm for ANY gate that reads a
// name.  § arrayBcastPortPositionalNoFormal12's gate does NOT read a name — it
// is `hasOrderedConns`, a walk over the connection list's SYNTAX KINDS — but the
// thing the law DELETES is a name (`port->VpiName`) and the thing it rewrites is
// a fullname, so an escaped formal or an escaped actual is exactly where a
// name-shaped law can go wrong.  This arm holds the law's two branches against
// escaped names on BOTH sides of the connection.
//
// slang keeps the leading backslash and the trailing space OUT of the symbol
// name (`\clk ` -> `clk`), so the interesting cells are the ones where the
// escaped spelling differs from a legal plain spelling (`e$c` in e2/e4): if the
// producer ever reconstructed the name from source text instead of the symbol,
// those are the cells that would show it.
interface ifE(input bit clk, input bit \r$t );
  logic sig;
endinterface

module top();

bit Clock;
bit \Cl$ck ;
bit Rst;

// e1  POSITIONAL, escaped ACTUAL           -> nameless port, no formal in scope
ifE e1[4](\Cl$ck , Rst);
// e2  NAMED, escaped FORMAL and actual     -> formal-named port, formal in scope
ifE e2[4](.clk(Clock), .\r$t (Rst));
// e3  POSITIONAL, 1 conn, escaped actual
ifE e3[2](\Cl$ck );
// e4  NAMED, 1 conn, escaped formal only
ifE e4[2](.\r$t (Rst));

endmodule
