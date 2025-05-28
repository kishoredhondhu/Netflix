public interface BudgetService {
    BudgetCategoryDTO addCategory(BudgetCategoryDTO dto);
    List<BudgetCategoryDTO> getProjectBudget(Long projectId);
    BudgetLineItemDTO addLineItem(BudgetLineItemDTO dto);
    void deleteLineItem(Long id);
    BudgetLineItemDTO updateLineItem(BudgetLineItemDTO dto);
}


@Service
@RequiredArgsConstructor
public class BudgetServiceImpl implements BudgetService {

    private final BudgetCategoryRepository categoryRepo;
    private final BudgetLineItemRepository lineItemRepo;
    private final MovieProjectRepository projectRepo;
    private final ModelMapper mapper;

    @Override
    public BudgetCategoryDTO addCategory(BudgetCategoryDTO dto) {
        MovieProject project = projectRepo.findById(dto.getProjectId())
                .orElseThrow(() -> new RuntimeException("Project not found"));

        BudgetCategory category = BudgetCategory.builder()
                .categoryName(dto.getCategoryName())
                .project(project)
                .build();

        return mapper.map(categoryRepo.save(category), BudgetCategoryDTO.class);
    }

    @Override
    public List<BudgetCategoryDTO> getProjectBudget(Long projectId) {
        return categoryRepo.findByProjectId(projectId).stream()
                .map(category -> {
                    List<BudgetLineItemDTO> items = category.getLineItems().stream()
                            .map(item -> mapper.map(item, BudgetLineItemDTO.class))
                            .toList();
                    return BudgetCategoryDTO.builder()
                            .id(category.getId())
                            .categoryName(category.getCategoryName())
                            .projectId(projectId)
                            .lineItems(items)
                            .build();
                }).toList();
    }

    @Override
    public BudgetLineItemDTO addLineItem(BudgetLineItemDTO dto) {
        BudgetCategory category = categoryRepo.findById(dto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));

        BudgetLineItem item = BudgetLineItem.builder()
                .itemName(dto.getItemName())
                .estimatedCost(dto.getEstimatedCost())
                .actualCost(dto.getActualCost())
                .category(category)
                .build();

        return mapper.map(lineItemRepo.save(item), BudgetLineItemDTO.class);
    }

    @Override
    public void deleteLineItem(Long id) {
        lineItemRepo.deleteById(id);
    }

    @Override
    public BudgetLineItemDTO updateLineItem(BudgetLineItemDTO dto) {
        BudgetLineItem item = lineItemRepo.findById(dto.getId())
                .orElseThrow(() -> new RuntimeException("Line item not found"));

        item.setItemName(dto.getItemName());
        item.setEstimatedCost(dto.getEstimatedCost());
        item.setActualCost(dto.getActualCost());

        return mapper.map(lineItemRepo.save(item), BudgetLineItemDTO.class);
    }
}
