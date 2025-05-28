@RestController
@RequestMapping("/api/budget")
@RequiredArgsConstructor
public class BudgetController {

    private final BudgetService service;

    @PostMapping("/category")
    public ResponseEntity<BudgetCategoryDTO> createCategory(@RequestBody BudgetCategoryDTO dto) {
        return ResponseEntity.ok(service.addCategory(dto));
    }

    @PostMapping("/line-item")
    public ResponseEntity<BudgetLineItemDTO> createLineItem(@RequestBody BudgetLineItemDTO dto) {
        return ResponseEntity.ok(service.addLineItem(dto));
    }

    @PutMapping("/line-item")
    public ResponseEntity<BudgetLineItemDTO> updateLineItem(@RequestBody BudgetLineItemDTO dto) {
        return ResponseEntity.ok(service.updateLineItem(dto));
    }

    @DeleteMapping("/line-item/{id}")
    public ResponseEntity<Void> deleteLineItem(@PathVariable Long id) {
        service.deleteLineItem(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<BudgetCategoryDTO>> getBudgetByProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(service.getProjectBudget(projectId));
    }
}
