; extends

; Mute receivers so property and method names stand out.
((member_expression
  object: (identifier) @variable.member_receiver)
  (#set! "priority" 130))

; Keep arrow/function-expression variable names gold even when semantic tokens
; classify them as variables.
(variable_declarator
  name: (identifier) @function
  value: [(arrow_function) (function_expression)])
  (#set! "priority" 130)

(assignment_expression
  left: (identifier) @function
  right: [(arrow_function) (function_expression)])
  (#set! "priority" 130)
