`define INNER(m) $display("%s", m);
`define OUTER(o) \
  begin \
    `INNER(o.name()) \
  end
