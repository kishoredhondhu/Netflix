public interface BudgetCategoryRepository extends JpaRepository<BudgetCategory, Long> {
    List<BudgetCategory> findByProjectId(Long projectId);
}

public interface BudgetLineItemRepository extends JpaRepository<BudgetLineItem, Long> {
    List<BudgetLineItem> findByCategoryId(Long categoryId);
}

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BudgetLineItemDTO {
    private Long id;
    private String itemName;
    private Double estimatedCost;
    private Double actualCost;
    private Long categoryId;
}


@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BudgetCategoryDTO {
    private Long id;
    private String categoryName;
    private Long projectId;
    private List<BudgetLineItemDTO> lineItems;
}
