---
name: tailwind-cn-readability
description: Refactors long Tailwind className strings into readable cn(...) groups while preserving behavior. Use when the user asks to split Tailwind classes, improve Tailwind readability, organize className values, or use cn/twMerge/class merging for Tailwind classes.
---

# Tailwind cn Readability

## Quick start

Convert long `className` strings into grouped `cn(...)` calls. Do not add section comments for normal Tailwind groups:
```tsx
className={cn(
  // Hero reveal animation
  "landing-hero-reveal landing-hero-reveal--delayed",
  "absolute right-8 bottom-8 left-auto",
  "hidden md:inline-flex items-center gap-2",
  "py-2",
  "text-sm md:text-base text-muted-foreground",
)}
```

Keep responsive variants next to the class they change when it improves readability.

## Workflow

1. Confirm the file already has a `cn` utility import, or add the project's existing `cn` import only when needed.
2. Find long Tailwind `className="..."` or `className={"..."}` values.
3. Convert to `className={cn(...)}` only when the classes naturally split into three or more meaningful sections, or when conditional classes need merging.
4. If all classes belong to one section, keep the plain string and do not wrap it in `cn(...)`
5. Split grouped classes into readable lines without Tailwind category comments. Only add comments for custom/non-Tailwind classes, and name what they do.
6. Preserve behavior exactly: do not add, remove, or rename classes unless the user asks.
7. Keep conflicting utilities in safe order inside the same group.

## Group order

Use this default order:

1. Purpose-specific custom classes, named by what they do
2. Positioning
3. Display / layout
4. Sizing
5. Spacing
6. Typography
7. Background / borders
8. Effects / transforms / transitions
9. Interaction / state
10. Misc

Only include sections that are needed. Prefer fewer clear class strings over many tiny strings. Do not add comments like `Positioning`, `Display / layout`, `Spacing`, or `Typography`; they add noise. Only comment custom/non-Tailwind classes, and never label them `Custom classes`. Name what they do, such as `Hero reveal animation`, `Booking calendar state`, or `Marketing badge style`.

## Responsive variants

Prefer colocating responsive variants with the related base class:
```tsx
"hidden md:inline-flex items-center gap-2",
"text-sm md:text-base text-muted-foreground",
```

This is safe because Tailwind variants do not need to appear at the end to work.

## Safety rules

- Keep arbitrary values as-is; do not replace them unless specifically requested.
- Avoid nested ternaries or complex conditional class logic. If conditionals are needed, keep them readable with named booleans or object entries.
- If classes are duplicated, only remove duplicates when it is obviously behavior-preserving.

## Conditional classes

For conditional classes, keep base groups first and conditionals after the relevant static classes:
```tsx
className={cn(
  "flex items-center gap-2",
  "px-4 py-2",
  "text-sm font-medium",
  isActive && "text-primary",
  isDisabled && "pointer-events-none opacity-50",
)}
```
