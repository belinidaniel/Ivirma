/**
 * @description  : LWC Dynamic Banner Controller
 * @author       : Ivo Rocha
 **/
public without sharing class LwcDynamicBannerController {
	@AuraEnabled(cacheable=true)
	public static List<String> evaluateText(Id recordId, List<String> textsToProcess) {
		Schema.SObjectType sObjectType = recordId.getSObjectType();

		// Collect fields to be used in the formula
		Set<String> fields = new Set<String>();
		fields.add('Id');
		for (String text : textsToProcess) {
			if (String.isBlank(text)) {
				continue;
			}
			try {
				FormulaEval.FormulaInstance formulaInstance = Formula.builder()
					.withType(sObjectType)
					.withReturnType(FormulaEval.FormulaReturnType.String)
					.withFormula(text)
					.build();
				fields.addAll(formulaInstance.getReferencedFields());
			} catch (Exception ex) {
				System.debug(LoggingLevel.ERROR, 'Error extracting formula fields: ' + ex.getMessage());
			}
		}
		// Build the query
		String query = String.format(
			'SELECT {0} FROM {1} WHERE Id = :recordId LIMIT 1',
			new List<String>{ String.join(fields, ','), sObjectType.getDescribe().getName() }
		);
		SObject record = Database.query(query)[0];

		List<String> outputs = new List<String>();
		for (String text : textsToProcess) {
			try {
				FormulaEval.FormulaInstance formulaInstance = Formula.builder()
					.withType(sObjectType)
					.withReturnType(FormulaEval.FormulaReturnType.String)
					.withFormula(text)
					.build();
				String output = (String) formulaInstance.evaluate(record);
				System.debug(LoggingLevel.INFO, output);
				outputs.add(output);
			} catch (Exception ex) {
				System.debug(LoggingLevel.ERROR, 'Error processing formula: ' + ex.getMessage());
				// If there is any error with the formula, consider the text as literal
				outputs.add(text);
			}
		}
		return outputs;
	}
}
