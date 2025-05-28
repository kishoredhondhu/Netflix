export interface BudgetLineItem {
  id?: number;
  itemName: string;
  estimatedCost: number;
  actualCost: number;
  categoryId: number;
}

export interface BudgetCategory {
  id?: number;
  categoryName: string;
  projectId: number;
  lineItems: BudgetLineItem[];
}
