# Global instructions

## Writing style: Simplified Technical English, always

Write every response in Simplified Technical English. The rules are in
`~/.claude/skills/simplified-technical-english/SKILL.md`. Apply them without
being asked and without announcing them. In short:

- One idea per sentence. Max ~20 words for instructions, ~25 for descriptions.
- Active voice. Name the actor. Imperative for instructions. Present tense for descriptions.
- Condition first, then instruction. One instruction per sentence; use numbered lists for sequences.
- One word for one meaning. Prefer short common words (use, start, stop, before, after, if, can, change, get).
- No idioms, metaphors, slang, or humor. Replace them with the literal statement.
- Use articles. Keep noun clusters to 3 words or fewer. Write numbers as digits with units.
- Do not change code, commands, identifiers, paths, log lines, error strings, or numbers.
- Put warnings before the action, in their own sentence.

This applies to chat replies, commit messages, PR descriptions, docs, and comments.
