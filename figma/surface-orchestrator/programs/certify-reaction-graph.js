/*__FIGMA_INPUT__*/

if (typeof INPUT.pageId !== "string" || INPUT.pageId.length === 0) {
  throw new Error("pageId must be a non-empty string");
}
if (
  INPUT.edgeNamePattern !== undefined &&
  (typeof INPUT.edgeNamePattern !== "string" || INPUT.edgeNamePattern.length === 0)
) {
  throw new Error("edgeNamePattern must be a non-empty regular expression string");
}
if (INPUT.expected !== undefined && !Array.isArray(INPUT.expected)) {
  throw new Error("expected must be an array when provided");
}

const page = await figma.getNodeByIdAsync(INPUT.pageId);
if (!page || page.type !== "PAGE") {
  throw new Error(`Page not found: ${INPUT.pageId}`);
}
await figma.setCurrentPageAsync(page);

let edgePattern;
try {
  edgePattern = new RegExp(INPUT.edgeNamePattern ?? "^E\\d+$");
} catch (error) {
  throw new Error(`Invalid edgeNamePattern: ${error.message}`);
}

const edgeNodes = page.findAll((node) => edgePattern.test(node.name));
const duplicateEdgeNames = [...new Set(
  edgeNodes
    .map((node) => node.name)
    .filter((name, index, names) => names.indexOf(name) !== index),
)];
const actual = [];
let reactionCount = 0;

for (const edgeNode of edgeNodes) {
  let owner = edgeNode;
  while (owner.parent && owner.parent.id !== page.id) {
    owner = owner.parent;
  }

  const reactions = Array.isArray(edgeNode.reactions) ? edgeNode.reactions : [];
  reactionCount += reactions.length;

  for (let reactionIndex = 0; reactionIndex < reactions.length; reactionIndex += 1) {
    const reaction = reactions[reactionIndex];
    const actions = Array.isArray(reaction.actions)
      ? reaction.actions
      : reaction.action
        ? [reaction.action]
        : [];

    if (actions.length === 0) {
      actual.push({
        edgeName: edgeNode.name,
        edgeNodeId: edgeNode.id,
        sourceNodeId: owner.id,
        sourceName: owner.name,
        reactionIndex,
        actionIndex: null,
        triggerType: reaction.trigger?.type ?? null,
        actionType: null,
        navigation: null,
        targetNodeId: null,
        targetName: null,
      });
      continue;
    }

    for (let actionIndex = 0; actionIndex < actions.length; actionIndex += 1) {
      const action = actions[actionIndex];
      const targetNodeId = action.destinationId ?? null;
      const target = targetNodeId ? await figma.getNodeByIdAsync(targetNodeId) : null;
      actual.push({
        edgeName: edgeNode.name,
        edgeNodeId: edgeNode.id,
        sourceNodeId: owner.id,
        sourceName: owner.name,
        reactionIndex,
        actionIndex,
        triggerType: reaction.trigger?.type ?? null,
        actionType: action.type ?? null,
        navigation: action.navigation ?? null,
        targetNodeId,
        targetName: target?.name ?? null,
      });
    }
  }
}

const expected = INPUT.expected ?? [];
const comparableFields = [
  "edgeName",
  "edgeNodeId",
  "sourceNodeId",
  "sourceName",
  "reactionIndex",
  "actionIndex",
  "triggerType",
  "actionType",
  "navigation",
  "targetNodeId",
  "targetName",
];
const mismatches = expected.flatMap((expectedEdge, expectedIndex) => {
  if (!expectedEdge || typeof expectedEdge !== "object" || Array.isArray(expectedEdge)) {
    return [{ expectedIndex, reason: "expected entry must be an object", expected: expectedEdge }];
  }
  if (typeof expectedEdge.edgeName !== "string" || expectedEdge.edgeName.length === 0) {
    return [{ expectedIndex, reason: "expected entry requires edgeName", expected: expectedEdge }];
  }

  const candidate = actual.find((actualEdge) =>
    comparableFields.every((field) =>
      expectedEdge[field] === undefined || expectedEdge[field] === actualEdge[field]
    )
  );
  return candidate
    ? []
    : [{ expectedIndex, reason: "no matching persisted reaction action", expected: expectedEdge }];
});

return {
  page: {
    id: page.id,
    name: page.name,
  },
  counts: {
    namedEdgeLayers: edgeNodes.length,
    duplicateEdgeNames: duplicateEdgeNames.length,
    reactions: reactionCount,
    normalizedActions: actual.length,
    expected: expected.length,
    mismatches: mismatches.length,
  },
  duplicateEdgeNames,
  mismatches,
  actual,
  ok: duplicateEdgeNames.length === 0 && mismatches.length === 0,
};
