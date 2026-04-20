#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FileContext {
    pub left_file_content: String,
    pub right_file_content: String,
    pub filename: String,
    pub programming_language: ProgrammingLanguage,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProgrammingLanguage {
    pub language_name: LanguageName,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, strum::AsRefStr)]
#[serde(rename_all = "lowercase")]
#[strum(serialize_all = "lowercase")]
pub enum LanguageName {
    Python,
    Javascript,
    Java,
    Csharp,
    Typescript,
    C,
    Cpp,
    Go,
    Kotlin,
    Php,
    Ruby,
    Rust,
    Scala,
    Shell,
    Sql,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReferenceTrackerConfiguration {
    pub recommendations_with_references: RecommendationsWithReferences,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "UPPERCASE")]
pub enum RecommendationsWithReferences {
    Block,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RecommendationsInput {
    pub file_context: FileContext,
    pub max_results: i32,
    pub next_token: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RecommendationsOutput {
    pub recommendations: Vec<Recommendation>,
    pub next_token: Option<String>,
    pub session_id: Option<String>,
    pub request_id: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Recommendation {
    pub content: String,
}
