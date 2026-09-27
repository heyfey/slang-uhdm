// § tdMoveKeyResolved176 § tdMoveCarriesFile172 § mlArgLocFileAtActual177v
`define FN(nm, ty) function automatic logic nm(ty v); return v.y; endfunction
package pa;
  typedef struct packed { logic [1:0] x; logic y; } s_t;
endpackage
