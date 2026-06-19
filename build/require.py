import re

REQUIRE_PATTERN = re.compile(r'require\s*\(\s*["\']([^"\']+)["\']\s*\)')


def convert_relative_require(path: str) -> str:
    if not (path.startswith("./") or path.startswith("../")):
        return None

    result = ["script", "Parent"]

    while path.startswith("../"):
        result.append("Parent")
        path = path[3:]

    if path.startswith("./"):
        path = path[2:]

    for part in path.split("/"):
        if part:
            result.append(part)

    return ".".join(result)


def rewrite_requires(source: str) -> str:
    def replacer(match):
        path = match.group(1)

        resolved = convert_relative_require(path)

        if resolved is None:
            return match.group(0)

        return f"require({resolved})"

    return REQUIRE_PATTERN.sub(replacer, source)
